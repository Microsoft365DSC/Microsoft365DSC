using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntunePolicySets : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Description of the PolicySet.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the PolicySet.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Tags of the guided deployment')]
    [System.String[]] $GuidedDeploymentTags

    [DscProperty()]
    [System.ComponentModel.Description('RoleScopeTags of the PolicySet')]
    [System.String[]] $RoleScopeTags

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyItems[]] $Items

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

    [IntunePolicySets] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntunePolicySets]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Policy Sets with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                $getValue = Get-MgBetaDeviceAppManagementPolicySet -PolicySetId $this.Id -ExpandProperty * -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Policy Sets with Id {$($this.Id)}"

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    [array]$getValue = Get-MgBetaDeviceAppManagementPolicySet `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"

                    if ($null -eq $getValue)
                    {
                        Write-Verbose -Message "Could not find an Intune Policy Sets with DisplayName {$($this.DisplayName)}"
                        return $this.AsResult($nullResult)
                    }
                    else
                    {
                        if ($getValue.Count -gt 1)
                        {
                            Write-Verbose -Message "Multiple Intune Policy Sets with DisplayName {$($this.DisplayName)} - unable to continue"
                            return $this.AsResult($nullResult)
                        }
                        else
                        {
                            $getValue = Get-MgBetaDeviceAppManagementPolicySet -PolicySetId $getValue.Id -ExpandProperty * -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Policy Sets with DisplayName {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Policy Sets with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                GuidedDeploymentTags  = $getValue.GuidedDeploymentTags
                RoleScopeTags         = $getValue.RoleScopeTags
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
                AccessTokens          = $this.AccessTokens
                #endregion
            }

            if ($null -eq $getValue.GuidedDeploymentTags)
            {
                $results.GuidedDeploymentTags = @()
            }

            $assignmentsValues = $getValue.Assignments
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
            }
            $results.Add('Assignments', $assignmentResult)

            $itemsValues = $getValue.Items

            $itemResult = @()
            $this.ResourceCache['itemResultCache'] = @()
            foreach ($itemEntry in $itemsValues)
            {
                $itemValue = @{
                    dataType             = $itemEntry.'@odata.type'
                    payloadId            = $itemEntry.PayloadId
                    itemType             = $itemEntry.ItemType
                    displayName          = $itemEntry.displayName
                    guidedDeploymentTags = $itemEntry.GuidedDeploymentTags
                }
                $itemResult += $itemValue

                $itemValue = $itemValue.Clone()
                $itemValue.Add('id', $itemEntry.Id)
                $this.ResourceCache['itemResultCache'] += $itemValue
            }

            $results.Add('Items', $itemResult)

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
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Policy Sets with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            # remove complex values
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Items') | Out-Null
            # remove unused values
            $createParameters.Remove('Id') | Out-Null

            # set assignments and items to work with New-MgBetaDeviceAppManagementPolicySet command
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            $createParameters.Add('assignments', $assignmentsHash)

            $itemsHash = @()
            foreach ($item in $this.items)
            {
                $itemsHash += @{
                    payloadId            = $this.GetPayloadIdFromItem($item)
                    '@odata.type'        = $item.dataType
                    guidedDeploymentTags = @($item.guidedDeploymentTags | Where-Object -FilterScript { $null -ne $_ })
                }
            }
            $createParameters.Add('items', $itemsHash)
            $policy = New-MgBetaDeviceAppManagementPolicySet -BodyParameter $createParameters

            if ($policy.id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                $url = "/beta/deviceAppManagement/policySets/$($policy.Id)/update"
                Invoke-M365DSCGraphRequest -Method POST -Uri $url -Body @{
                    assignments = $assignmentsHash
                }
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Policy Sets with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            # remove complex values
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Items') | Out-Null
            # remove unused values
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Update-MgBetaDeviceAppManagementPolicySet -PolicySetId $currentInstance.Id -BodyParameter $updateParameters

            if ($null -ne ($itemamendments = $this.GetItemsAmendmentsObject($this.ResourceCache['itemResultCache'], $this.items)))
            {
                Write-Verbose $($itemamendments | ConvertTo-Json -Depth 10) -Verbose
                Update-MgBetaDeviceAppManagementMultiplePolicySet -PolicySetId $currentInstance.Id `
                    -BodyParameter $itemamendments
            }

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-MgBetaDeviceAppManagementMultiplePolicySet -PolicySetId $currentInstance.Id `
                -Assignments $assignmentsHash
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Policy Sets with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementPolicySet -PolicySetId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaDeviceAppManagementPolicySet -Filter $this.Filter -All -ErrorAction Stop
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
                if ($Results.Items)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Items -CIMInstanceName DeviceManagementConfigurationPolicyItems
                    if ($complexTypeStringResult)
                    {
                        $Results.Items = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Items') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'Items') `
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
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or
                $_.Exception -like '* Unauthorized*' -or `
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
            ExcludedProperties = @('PayloadId')
        }
    }

    hidden [System.Object] GetItemsAmendmentsObject([System.Object] $currentObjectItems, [System.Object] $targetObjectItems)
    {
        $nullreturn = $true
        $ItemsModificationTemplate = @{
            deletedPolicySetItems = @()
            updatedPolicySetItems = @()
            addedPolicySetItems   = @()
        }

        $nullreturn = $true
        $currentObjectItems | ForEach-Object {
            if (-not ($targetObjectItems.DisplayName -contains $_.DisplayName))
            {
                Write-Verbose -Message ($_.DisplayName + ' NOT present in Config Document, Removing')
                $ItemsModificationTemplate.deletedPolicySetItems += $_.id
                $nullreturn = $false
            }
        }

        $targetObjectItems | ForEach-Object {
            if (-not ($currentObjectItems.DisplayName -contains $_.DisplayName))
            {
                Write-Verbose -Message ($_.DisplayName + ' NOT already present in Policy Set, Adding')
                $ItemsModificationTemplate.addedPolicySetItems += @{
                    payloadId            = $this.GetPayloadIdFromItem($_)
                    '@odata.type'        = $_.dataType
                    guidedDeploymentTags = @($_.guidedDeploymentTags | Where-Object -FilterScript { $null -ne $_ })
                }
                $nullreturn = $false
            }
        }

        if (-not $nullreturn)
        {
            return $ItemsModificationTemplate
        }

        return $null
    }

    hidden [System.String] GetPayloadIdFromItem([System.Object] $Item)
    {
        $object = $null
        switch ($Item.dataType)
        {
            '#microsoft.graph.windowsAutopilotDeploymentProfilePolicySetItem'
            {
                $object = Get-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -WindowsAutopilotDeploymentProfileId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceManagementWindowsAutopilotDeploymentProfile -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.deviceCompliancePolicyPolicySetItem'
            {
                $object = Get-MgBetaDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceManagementDeviceCompliancePolicy -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.deviceConfigurationPolicySetItem'
            {
                $object = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceManagementDeviceConfiguration -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.mobileAppPolicySetItem'
            {
                $object = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceAppManagementMobileApp -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.targetedManagedAppConfigurationPolicySetItem'
            {
                $object = Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -TargetedManagedAppConfigurationId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.managedAppProtectionPolicySetItem'
            {
                $object = Get-MgBetaDeviceAppManagementManagedAppPolicy -ManagedAppPolicyId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceAppManagementManagedAppPolicy -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
            '#microsoft.graph.windows10EnrollmentCompletionPageConfigurationPolicySetItem'
            {
                $object = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $Item.payloadId -ErrorAction SilentlyContinue
                if ($null -eq $object)
                {
                    if ($null -eq $Item.displayName)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and no displayName to fallback on"
                    }
                    $object = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -Filter "displayName eq '$($Item.displayName)'" -All -ErrorAction SilentlyContinue
                    if ($null -eq $object)
                    {
                        throw "Unable to find the item with payloadId $($Item.payloadId) and displayName $($Item.displayName)"
                    }
                }
            }
        }

        return $object.Id
    }

    hidden [IntunePolicySets] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntunePolicySets])
        {
            return $Values
        }

        $result = [IntunePolicySets]::new()
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

class MSFT_DeviceManagementConfigurationPolicyItems
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of policy the item represents.')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The group Id of the policy the item represents.')]
    [System.String] $payloadId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The collection display name of the policy the item represents')]
    [System.String] $displayName

    [DscProperty()]
    [System.ComponentModel.Description('The type of policy the item represents.')]
    [System.String] $itemType

    [DscProperty()]
    [System.ComponentModel.Description('Tags of the guided deployment')]
    [System.String[]] $guidedDeploymentTags
}
